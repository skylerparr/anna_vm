package matcher;

import lang.MatchValue;
import lang.MatchData;
interface Matcher {
  function match(left:MatchValue, right:Dynamic):MatchData;
}