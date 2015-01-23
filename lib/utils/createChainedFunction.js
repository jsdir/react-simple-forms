/**
 * Safe chained function
 *
 * Will only create a new function if needed,
 * otherwise will pass back existing functions or null.
 *
 * @param {function} one
 * @param {function} two
 * @returns {function|null}
 */
const createChainedFunction = (one, two) => {
  var hasOne = typeof one === 'function';
  var hasTwo = typeof two === 'function';

  if (!hasOne && !hasTwo) {return null;}
  if (!hasOne) {return two;}
  if (!hasTwo) {return one;}

  return chainedFunction = () => {
    one.apply(this, arguments);
    two.apply(this, arguments);
  };
};

module.exports = createChainedFunction;

export default createChainedFunction;