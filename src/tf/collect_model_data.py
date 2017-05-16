import keras
import time
import numpy as np
from keras import backend as K
from keras.applications.inception_v3 import InceptionV3
from keras.applications.vgg16 import VGG16
from keras.applications.resnet50 import ResNet50
from keras.layers.normalization import BatchNormalization

from keras_profiling import keras_profiling_hack

def benchmark_model(model):
  for layer in model.layers:
    layer.trainable = False
  model.compile(optimizer="sgd", loss="mse")

  batch_size = 64
  batch_shape = (batch_size,) + model.input_shape[1:]
  batch = np.random.randn(*batch_shape)

  print("Benchmarking")
  # Run once to make sure the GPU is ready.
  model.predict_on_batch(batch)

  N = 25
  start = time.time()
  for _ in range(N):
    model.predict_on_batch(batch)
  end = time.time()

  print(
    "Ran {} frames in {}s, at {} fps".format(N * batch_size, end - start, N * batch_size / (end - start)))

def show_model_data():
  K.set_image_data_format("channels_last")
  # K.set_image_data_format("channels_first")
  #keras_profiling_hack()
  inception = InceptionV3()
  inception.summary()

  vgg16 = VGG16()
  vgg16.summary()

  resnet = ResNet50()
  resnet.summary()

  print("Inception V3")
  benchmark_model(inception)

  print("VGG16")
  benchmark_model(vgg16)

  print("ResNet50")
  benchmark_model(resnet)


if __name__ == "__main__":
  show_model_data()
