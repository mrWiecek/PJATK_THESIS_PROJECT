import tensorflow as tf
from keras import layers
from config import GLOBALS
import yaml
import os
import fire
import onnx
import tf2onnx

params = yaml.safe_load(open(os.path.join(GLOBALS["BASE_DIR"], "params.yaml")))
params_features = params["featurize"]
params_train = params["train"]

os.environ['TF_KERAS'] = '1'


def get_data(data_filepath):
    features_train_ds = tf.data.experimental.load(os.path.join(data_filepath, "train"))
    features_test_ds = tf.data.experimental.load(os.path.join(data_filepath, "test"))
    features_val_ds = tf.data.experimental.load(os.path.join(data_filepath, "val"))
    return features_train_ds, features_test_ds, features_val_ds

def train(model_filepath='models', feature_data_filepath='data/features'):
    train_ds, test_ds, val_ds = get_data(feature_data_filepath)
    # Do async prefetching / buffering of the data for best performance on GPU.
    train_ds = train_ds.cache().prefetch(buffer_size=10)
    val_ds = val_ds.cache().prefetch(buffer_size=10)
    test_ds = test_ds.cache().prefetch(buffer_size=10)

    # A integer input for vocab indices.
    inputs = tf.keras.Input(shape=(None,), dtype="int64")

    # Next, we add a layer to map those vocab indices into a space of dimensionality
    # 'embedding_dim'.
    x = layers.Embedding(
        params_features["max_features"], params_features["embedding_dim"]
    )(inputs)
    x = layers.Dropout(params_train['model_dropout'])(x)

    # Conv1D + global max pooling
    x = layers.Conv1D(params_train['model_kernel_size'], params_train['model_padding'], padding="valid", activation="relu", strides=params_train['model_strides'])(x)
    x = layers.Conv1D(params_train['model_kernel_size'], params_train['model_padding'], padding="valid", activation="relu", strides=params_train['model_strides'])(x)
    x = layers.GlobalMaxPooling1D()(x)

    # We add a vanilla hidden layer:
    x = layers.Dense(params_train['model_kernel_size'], activation="relu")(x)
    x = layers.Dropout(params_train['model_dropout'])(x)

    # We project onto a single unit output layer, and squash it with a sigmoid:
    predictions = layers.Dense(1, activation="sigmoid", name="predictions")(x)

    model = tf.keras.Model(inputs, predictions, name="mlops-thesis-text-classification")
    # Compile the model with binary crossentropy loss and an adam optimizer.
    model.compile(loss="binary_crossentropy", optimizer="adam", metrics=["accuracy"])

    # Fit the model using the train and test datasets.
    model.fit(train_ds, validation_data=val_ds, epochs=params_train['epochs'])

    # Save model
    input_signature = [tf.TensorSpec([1, 7, 7, 128], tf.float32, name=f'{model.name}-sig')]

    # Use from_function for tf functions
    onnx_model, _ = tf2onnx.convert.from_keras(model, input_signature, opset=13)
    onnx.save(onnx_model, f"{model.name}.onnx")

if __name__ == "__main__":
    fire.Fire(train)