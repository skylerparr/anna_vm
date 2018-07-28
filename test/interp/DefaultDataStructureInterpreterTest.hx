package interp;

import lang.MatchData;
import error.UnableToInterpretStringError;
import lang.MatchValue;
import lang.Types.Tuple;
import lang.Types;
import massive.munit.Assert;
import util.Matcher;


class DefaultDataStructureInterpreterTest {

  private var interp: DefaultDataStructureInterpreter;

  @Before
  public function setup():Void {
    interp = new DefaultDataStructureInterpreter();
    interp.init();
  }

  @After
  public function tearDown():Void {
    interp.dispose();
    interp = null;
  }

  @Test
  public function shouldEncodeStringWithIntegerConstant(): Void {
    var left: MatchValue = interp.encode("  143\n");
    var right: Int = 143;
    Assert.isTrue(Matcher.match(left, right, new Map<String, Dynamic>()).matched);
  }

  @Test
  public function shouldEncodeStringWithIntegerConstantAndBackToString(): Void {
    var left: MatchValue = interp.encode("\n\t  \n143  \t");
    var right: Int = 143;
    Assert.areEqual(interp.toString(left), "143");
  }

  @Test
  public function shouldThrowExceptionIfUnableToInterpretNumberString(): Void {
    try {
      interp.encode("dad143f");
      Assert.isTrue(false);
    } catch(e: UnableToInterpretStringError) {
      Assert.isTrue(true);
    }
  }

  @Test
  public function shouldEncodeStringWithStringConstant(): Void {
    var left: MatchValue = interp.encode("\"  \n anna is watching 2 tv's \t\"");
    var right: String = "  \n anna is watching 2 tv's \t";
    Assert.areEqual(left.value, right);
    Assert.isTrue(Matcher.match(left, right, new Map<String, Dynamic>()).matched);
  }

  @Test
  public function shouldEncodeStringWithNumberAsStringConstant(): Void {
    var left: MatchValue = interp.encode("\"4356\"");
    var right: String = "4356";
    Assert.areEqual(left.value, right);
    Assert.isTrue(Matcher.match(left, right, new Map<String, Dynamic>()).matched);

    var left: MatchValue = interp.encode("\"0\"");
    var right: String = "0";
    Assert.areEqual(left.value, right);
    Assert.isTrue(Matcher.match(left, right, new Map<String, Dynamic>()).matched);

    var left: MatchValue = interp.encode("\"-143\"");
    var right: String = "-143";
    Assert.areEqual(left.value, right);
    Assert.isTrue(Matcher.match(left, right, new Map<String, Dynamic>()).matched);
  }

//  @Test
//  public function shouldEncodeStringWithStringConstantAndBackToString(): Void {
//    var left: MatchValue = interp.encode("\"Anna went to bed\"");
//    var right: String = "Anna went to bed";
//    Assert.areEqual(interp.toString(left), "\"Anna went to bed\"");
//  }
//
  @Test
  public function shouldThrowExceptionIfUnableToInterpretString(): Void {
    try {
      interp.encode("\"dad143f");
      Assert.isTrue(false);
    } catch(e: UnableToInterpretStringError) {
      Assert.isTrue(true);
    }
  }

  @Test
  public function shouldEncodeStringWithFloatConstant(): Void {
    var left: MatchValue = interp.encode("1.43");
    var right: Float = 1.43;
    Assert.isTrue(Matcher.match(left, right, new Map<String, Dynamic>()).matched);
  }

  @Test
  public function shouldEncodeStringWithFloatConstantAndBackToString(): Void {
    var left: MatchValue = interp.encode("1.43");
    var right: Float = 1.43;
    Assert.areEqual(interp.toString(left), "1.43");
  }

  @Test
  public function shouldThrowExceptionIfUnableToInterpretFloatString(): Void {
    try {
      interp.encode("e1.a43");
      Assert.isTrue(false);
    } catch(e: UnableToInterpretStringError) {
      Assert.isTrue(true);
    }
    try {
      interp.encode("fda1.43");
      Assert.isTrue(false);
    } catch(e: UnableToInterpretStringError) {
      Assert.isTrue(true);
    }
  }

  @Test
  public function shouldParseAtomString(): Void {
    var left: MatchValue = interp.encode(":anna");
    var right: Atom = {value: "anna", type: Types.ATOM};
    Assert.isTrue(Matcher.match(left, right, new Map<String, Dynamic>()).matched);
  }

  @Test
  public function shouldParseAtomWithQuotesAndSpaces(): Void {
    var left: MatchValue = interp.encode(":\"anna is so sweet\"");
    var right: Atom = {value: "anna is so sweet", type: Types.ATOM};
    Assert.isTrue(Matcher.match(left, right, new Map<String, Dynamic>()).matched);
  }

//  @Test
//  public function shouldParseAtomStringAndBackToString(): Void {
//    var left: MatchValue = interp.encode(":anna");
//    var right: Atom = {value: "anna", type: Types.ATOM};
//    Assert.isTrue(Matcher.match(left, right, new Map<String, Dynamic>()).matched);
//    Assert.areEqual(interp.toString(left), ":anna");
//  }

  @Test
  public function shouldCreateAnEmptyTuple(): Void {
    var left: MatchValue = interp.encode("{}");
    var right: Tuple = {value: [], type: Types.TUPLE};
    var matchData:MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateATupleWithASingleStringElement(): Void {
    var left: MatchValue = interp.encode("{\"foo\"}");
    var right: Tuple = {value: ["foo"], type: Types.TUPLE};
//    var matchData:MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
//    Assert.isTrue(matchData.matched);
  }
}