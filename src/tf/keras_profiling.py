import os
import time
from tempfile import mkdtemp

import keras
from keras import backend as K
import tensorflow as tf
from tensorflow.python.client import timeline

class ProfiledSession(tf.Session):
  def __init__(self, *args, **kwargs):
    super(ProfiledSession, self).__init__(*args, **kwargs)
    self._num = 0
    self._timeline_dir = None

  def run(self, *args, **kwargs):
    if "options" not in kwargs:
      kwargs["options"] = tf.RunOptions(trace_level=tf.RunOptions.FULL_TRACE)

    assert "run_metadata" not in kwargs, "Profiling would overwrite existing metadata"
    run_metadata = tf.RunMetadata()
    kwargs["run_metadata"] = run_metadata

    before = time.time()
    result = super(ProfiledSession, self).run(*args, **kwargs)
    after = time.time()

    print("Run took {}s".format(after - before))

    # Create the Timeline object, and write it to a json
    tl = timeline.Timeline(run_metadata.step_stats)
    ctf = tl.generate_chrome_trace_format()

    if self._timeline_dir is None:
      self._timeline_dir = mkdtemp()

    timeline_path = os.path.join(self._timeline_dir, "timeline_{}.json".format(self._num))
    self._num += 1
    with open(timeline_path, 'w') as f:
      f.write(ctf)
    print("Wrote timeline to {}".format(timeline_path))

    return result


def keras_profiling_hack():
  """Call this method before loading or building a Keras model to profile its usage.

     Outputs can be viewed with chrome://tracing.
  """
  curr_session = K.get_session()
  new_session = ProfiledSession(config=curr_session._config)
  curr_session.close()
  K.set_session(new_session)
  keras.backend.tensorflow_backend._initialize_variables()
