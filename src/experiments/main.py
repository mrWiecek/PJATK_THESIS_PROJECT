import tensorflow as tf
from keras.layers import TextVectorization

text = ["Power prices in Germany are among the highest in Europe.", "The high costs partly are due to the mandatory support for renewable energy sources – but most customers continue to support the country's energy transition regardless.","Wholesale electricity prices on average have been in decline in recent years, but surcharges, taxes, and grid fees raise the bill for Germany's private households and small businesses.","However, market observers say that power costs are often not even high enough for customers to look for cheaper alternatives.","At the same time, the 2021 energy price hike in Europe is upsetting government plans to ease the financial burden on housheholds by reducing fees and surcharges on consumption."]

vectorize_layer = TextVectorization(
    standardize='lower_and_strip_punctuation',
    max_tokens=50,
    output_mode="int",
    output_sequence_length=4
)

text_dataset = tf.data.Dataset.from_tensor_slices(
            tf.cast(text, tf.string)
) 

vectorize_layer.adapt(text_dataset)
vocab = vectorize_layer
print(vocab)