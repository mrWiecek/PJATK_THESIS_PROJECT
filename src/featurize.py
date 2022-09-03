import tensorflow as tf
import string
import yaml
import re
import os
import fire
from keras.layers import TextVectorization
from config import GLOBALS

params = yaml.safe_load(open(os.path.join(GLOBALS['BASE_DIR'], "params.yaml")))["featurize"]

# Model constants.
max_features = params['max_features']
embedding_dim = params['embedding_dim']
sequence_length = params['sequence_length']

# Create folders
os.makedirs(os.path.join("data", "features"), exist_ok=True)
for folder in ['train', 'val', 'test']:
    os.makedirs(os.path.join(os.path.join('data', 'features'), folder), exist_ok=True)

# Having looked at our data above, we see that the raw text contains HTML break
# tags of the form '<br />'. These tags will not be removed by the default
# standardizer (which doesn't strip HTML). Because of this, we will need to
# create a custom standardization function.
def custom_standardization(input_data):
    lowercase = tf.strings.lower(input_data)
    stripped_html = tf.strings.regex_replace(lowercase, "<br />", " ")
    return tf.strings.regex_replace(
        stripped_html, f"[{re.escape(string.punctuation)}]", ""
    )

def get_data(data):
    return tf.data.experimental.load(data)

def featurize(prepared_data_filepath='data/prepared', feature_data_filepath='data/features'):

    prepared_train_ds=get_data(os.path.join(prepared_data_filepath, 'train'))
    prepared_test_ds=get_data(os.path.join(prepared_data_filepath, 'test'))
    prepared_val_ds=get_data(os.path.join(prepared_data_filepath, 'val'))

    
    # Now that we have our custom standardization, we can instantiate our text
    # vectorization layer. We are using this layer to normalize, split, and map
    # strings to integers, so we set our 'output_mode' to 'int'.
    # Note that we're using the default split function,
    # and the custom standardization defined above.
    # We also set an explicit maximum sequence length, since the CNNs later in our
    # model won't support ragged sequences.
    vectorize_layer = TextVectorization(
        standardize=custom_standardization,
        max_tokens=max_features,
        output_mode="int",
        output_sequence_length=sequence_length,
    )

    # Now that the vocab layer has been created, call `adapt` on a text-only
    # dataset to create the vocabulary. You don't have to batch, but for very large
    # datasets this means you're not keeping spare copies of the dataset in memory.

    # Let's make a text-only dataset (no labels):
    text_ds = prepared_train_ds.map(lambda x, y: x)
    # Let's call `adapt`:
    vectorize_layer.adapt(text_ds)

    def vectorize_text(text, label):
        text = tf.expand_dims(text, -1)

        return vectorize_layer(text), label

    # Vectorize the data.
    train_ds = prepared_train_ds.map(vectorize_text)
    val_ds = prepared_val_ds.map(vectorize_text)
    test_ds = prepared_test_ds.map(vectorize_text)

    tf.data.experimental.save(train_ds, os.path.join(feature_data_filepath, 'train'))
    tf.data.experimental.save(test_ds, os.path.join(feature_data_filepath, 'test'))
    tf.data.experimental.save(val_ds, os.path.join(feature_data_filepath, 'val'))

if __name__ == "__main__":
    fire.Fire(featurize)