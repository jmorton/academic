/* Testing Code */

#include <limits.h>
int test_bitOr(int x, int y)
{
  return x|y;
}
int test_isEqual(int x, int y)
{
  return x == y;
}
int test_isNonZero(int x)
{
  return x!=0;
}
int test_isPositive(int x) {
  return x > 0;
}
int test_logicalNeg(int x)
{
  return !x;
}
int test_multFiveEights(int x)
{
  return (x*5)/8;
}
int test_negate(int x) {
  return -x;
}
int test_tc2sm(int x) {
  int sign = x < 0;
  int mag = x < 0 ? -x : x;
  return (sign << 31) | mag;
}
