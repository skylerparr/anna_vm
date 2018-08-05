package matcher;

import lang.MatchValue;
import lang.MatchData;
interface Matcher {
  function match(left:MatchValue, right:Dynamic, scope:Map<String, Dynamic>):MatchData;
}