import os
import yaml
import fire
import tensorflow as tf
from config import GLOBALS

params = yaml.safe_load(open(os.path.join(GLOBALS['BASE_DIR'], "params.yaml")))["prepare"]

os.makedirs(os.path.join("data", "prepared"), exist_ok=True)
for folder in ['train', 'val', 'test']:
    os.makedirs(os.path.join(os.path.join('data', 'prepared'), folder))

output_dir = os.path.join("data", "prepared")
batch_size = params["batch_size"]

def prepare(input):
    prepared_train_ds = tf.keras.preprocessing.text_dataset_from_directory(
        os.path.join(input, 'train'),
        batch_size=batch_size,
        validation_split=params["validation_split"],
        subset="training",
        seed=1337,
    )

    prepared_val_ds = tf.keras.preprocessing.text_dataset_from_directory(
        os.path.join(input, 'train'),
        batch_size=batch_size,
        validation_split=params["validation_split"],
        subset="validation",
        seed=1337,
    )

    prepared_test_ds = tf.keras.preprocessing.text_dataset_from_directory(
        os.path.join(input, 'test'), 
        batch_size=batch_size
    )

    tf.data.experimental.save(prepared_train_ds, os.path.join(output_dir, 'train'))
    tf.data.experimental.save(prepared_test_ds, os.path.join(output_dir, 'test'))
    tf.data.experimental.save(prepared_val_ds, os.path.join(output_dir, 'val'))

    print(f"Number of batches in prepared_train_ds: {prepared_train_ds.cardinality()}")
    print(f"Number of batches in prepared_val_ds: {prepared_val_ds.cardinality()}")
    print(f"Number of batches in prepared_test_ds: {prepared_test_ds.cardinality()}")

if __name__ == "__main__":
    fire.Fire(prepare)
