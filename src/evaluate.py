import os
import tensorflow as tf
import yaml
import keras
import json


params = yaml.safe_load(open("params.yaml"))["evaluate"]
features_test_ds = tf.data.experimental.load(os.path.join('data/features', "test"))
model = keras.models.load_model('models')


metrics_dict = model.evaluate(features_test_ds, return_dict=True)

with open(params['metrics'], "w") as f:
    f.write(json.dumps(metrics_dict))