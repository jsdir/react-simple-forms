/* jshint esnext: true */

import validate from 'validatejs';

export default function (constraints) {
  return ((data, cb) =>
    validate.async(data, constraints).then(() =>
      cb(null, data)
    ).catch(cb)
  );
}
