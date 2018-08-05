package interp;

import util.MapUtil;
import util.MapUtil;
import haxe.ds.StringMap;
import haxe.ds.ObjectMap;
import util.MapUtil;
import lang.HashTableAtoms;
import lang.AtomSupport;
import util.MatcherSupport;
import error.UnableToInterpretStringError;
import haxe.ds.ObjectMap;
import lang.MatchData;
import lang.MatchValue;
import lang.Types.Tuple;
import lang.Types;
import massive.munit.Assert;
import matcher.DefaultMatcher;

using lang.AtomSupport;

class DefaultDataStructureInterpreterTest {

  private var interp: DefaultDataStructureInterpreter;
  private var matcher: DefaultMatcher;

  @BeforeClass
  public function beforeClass():Void {
    var atoms: HashTableAtoms = new HashTableAtoms();
    AtomSupport.atoms = atoms;
  }

  @AfterClass
  public function afterClass():Void  {
    AtomSupport.atoms = null;
  }

  @Before
  public function setup():Void {
    matcher = new DefaultMatcher();

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
    Assert.isTrue(matcher.match(left, right, new Map<String, Dynamic>()).matched);

    var left: MatchValue = interp.encode("  -143\n");
    var right: Int = -143;
    Assert.isTrue(matcher.match(left, right, new Map<String, Dynamic>()).matched);
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
    Assert.isTrue(matcher.match(left, right, new Map<String, Dynamic>()).matched);
  }

  @Test
  public function shouldEncodeStringWithNumberAsStringConstant(): Void {
    var left: MatchValue = interp.encode("\"4356\"");
    var right: String = "4356";
    Assert.areEqual(left.value, right);
    Assert.isTrue(matcher.match(left, right, new Map<String, Dynamic>()).matched);

    var left: MatchValue = interp.encode("\"0\"");
    var right: String = "0";
    Assert.areEqual(left.value, right);
    Assert.isTrue(matcher.match(left, right, new Map<String, Dynamic>()).matched);

    var left: MatchValue = interp.encode("\"-143\"");
    var right: String = "-143";
    Assert.areEqual(left.value, right);
    Assert.isTrue(matcher.match(left, right, new Map<String, Dynamic>()).matched);
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
    Assert.isTrue(matcher.match(left, right, new Map<String, Dynamic>()).matched);
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
    Assert.isTrue(matcher.match(left, right, new Map<String, Dynamic>()).matched);
  }

  @Test
  public function shouldParseAtomWithQuotesAndSpaces(): Void {
    var left: MatchValue = interp.encode(":\"anna is so sweet\"");
    var right: Atom = {value: "anna is so sweet", type: Types.ATOM};
    Assert.isTrue(matcher.match(left, right, new Map<String, Dynamic>()).matched);
  }

//  @Test
//  public function shouldParseAtomStringAndBackToString(): Void {
//    var left: MatchValue = interp.encode(":anna");
//    var right: Atom = {value: "anna", type: Types.ATOM};
//    Assert.isTrue(matcher.match(left, right, new Map<String, Dynamic>()).matched);
//    Assert.areEqual(interp.toString(left), ":anna");
//  }

  @Test
  public function shouldCreateAnEmptyTuple(): Void {
    var left: MatchValue = interp.encode("{}");
    var right: Tuple = {value: [], type: Types.TUPLE};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateATupleWithASingleStringElement(): Void {
    var left: MatchValue = interp.encode("{\"foo\"}");
    var right: Tuple = {value: ["foo"], type: Types.TUPLE};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateATupleWithManyElementsAndTypes(): Void {
    var left: MatchValue = interp.encode("{\"foo\", 385, :anna}");
    var right: Tuple = {value: ["foo", 385, "anna".atom()], type: Types.TUPLE};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateATupleManyStrings(): Void {
    var left: MatchValue = interp.encode("{\"foo\", \"bar\", \"anna\"}");
    var right: Tuple = {value: ["foo", "bar", "anna"], type: Types.TUPLE};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateATupleManyAtoms(): Void {
    var left: MatchValue = interp.encode("{:foo, :\"anna\", :bar}");
    var right: Tuple = {value: ["foo".atom(), "anna".atom(), "bar".atom()], type: Types.TUPLE};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateATupleManyNumbers(): Void {
    var left: MatchValue = interp.encode("{100, 3490, 4939.34, 489, 950}");
    var right: Tuple = {value: [100, 3490, 4939.34, 489, 950], type: Types.TUPLE};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateTypeWithNestedTuple(): Void {
    var left: MatchValue = interp.encode("{{}}");
    var right: Tuple = {value: [{value: [], type: Types.TUPLE}], type: Types.TUPLE};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateTypeWithNestedTupleValue(): Void {
    var left: MatchValue = interp.encode("{{1,2,3},{4,5,6}}");
    var right: Tuple = {value: [{value: [1,2,3], type: Types.TUPLE},{value: [4,5,6], type: Types.TUPLE}], type: Types.TUPLE};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateEmptyList():Void {
    var left: MatchValue = interp.encode("[]");
    var rightList:List<Dynamic> = new List<Dynamic>();
    var right:LinkedList = {value: rightList, type: Types.LIST};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateListWithStringValues():Void {
    var left: MatchValue = interp.encode("[\"anna\", \"food\", \"bar\"]");

    var rightList:List<Dynamic> = new List<Dynamic>();
    rightList.add("anna");
    rightList.add("food");
    rightList.add("bar");
    var right:LinkedList = {value: rightList, type: Types.LIST};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateListWithAtomValues():Void {
    var left: MatchValue = interp.encode("[:\"anna\", :\"food\", :bar]");

    var rightList:List<Dynamic> = new List<Dynamic>();
    rightList.add("anna".atom());
    rightList.add("food".atom());
    rightList.add("bar".atom());
    var right:LinkedList = {value: rightList, type: Types.LIST};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateListWithNumberValues():Void {
    var left: MatchValue = interp.encode("[315, 621.64, 3492]");

    var rightList:List<Dynamic> = new List<Dynamic>();
    rightList.add(315);
    rightList.add(621.64);
    rightList.add(3492);
    var right:LinkedList = {value: rightList, type: Types.LIST};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateListWithAtoms():Void {
    var left: MatchValue = interp.encode("[:anna, :loves, :\"food\"]");

    var rightList:List<Dynamic> = new List<Dynamic>();
    rightList.add({value: "anna", type: Types.ATOM});
    rightList.add({value: "loves", type: Types.ATOM});
    rightList.add({value: "food", type: Types.ATOM});
    var right:LinkedList = {value: rightList, type: Types.LIST};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateListWithAtomsStringsAndNumbers():Void {
    var left: MatchValue = interp.encode("[:anna, :loves, 25, \"food\"]");

    var rightList:List<Dynamic> = new List<Dynamic>();
    rightList.add({value: "anna", type: Types.ATOM});
    rightList.add({value: "loves", type: Types.ATOM});
    rightList.add(25);
    rightList.add("food");
    var right:LinkedList = {value: rightList, type: Types.LIST};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateListWithNumbers():Void {
    var left: MatchValue = interp.encode("[-321, 25, 0, 43.243]");

    var rightList:List<Dynamic> = new List<Dynamic>();
    rightList.add(-321);
    rightList.add(25);
    rightList.add(0);
    rightList.add(43.243);
    var right:LinkedList = {value: rightList, type: Types.LIST};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateListWithAtomsStringsNumbersTuplesAndLists():Void {
    var left: MatchValue = interp.encode("[:anna, {:loves, 25, [\"food\"]}]");

    var rightList:List<Dynamic> = new List<Dynamic>();
    rightList.add({value: "anna", type: Types.ATOM});
    var foodList:List<Dynamic> = new List<Dynamic>();
    foodList.add("food");
    var tuple: Tuple = {value: [{value: "loves", type: Types.ATOM}, 25, {value: foodList, type: Types.LIST}], type: Types.TUPLE};
    rightList.add(tuple);
    var right:LinkedList = {value: rightList, type: Types.LIST};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateEmptyMap(): Void {
    var left: MatchValue = interp.encode("%{}");
    var rightMap:ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    var right:MatchObjectMap = {value: rightMap, type: Types.MAP};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateMapWithStringKeys(): Void {
    var left: MatchValue = interp.encode("%{\"anna\" => \"food\"}");
    var rightMap:Map<String, Dynamic> = new Map<String, Dynamic>();
    rightMap.set("anna", "food");
    var right:MatchStringMap = {value: rightMap, type: Types.MAP};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateMapWithAtomKeys(): Void {
    var left: MatchValue = interp.encode("%{:\"anna\" => \"food\"}");
    var rightMap:ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    rightMap.set("anna".atom(), "food");
    var right:MatchObjectMap = {value: rightMap, type: Types.MAP};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateMapWithMultipleAtomKeys(): Void {
    var left: MatchValue = interp.encode("%{:anna => \"food\", :foo => \"bar\"}");
    var rightMap:ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    rightMap.set("anna".atom(), "food");
    rightMap.set("foo".atom(), "bar");
    var right:MatchObjectMap = {value: rightMap, type: Types.MAP};
    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }

  @Test
  public function shouldCreateMapWithComplexValues(): Void {
    var left: MatchValue = interp.encode("%{:anna => \"food\", :bar => [1, 2, {:a, :b, :c}], :baz => %{}}");

    var barTuple: Tuple = {value: [{value: ["a".atom(), "b".atom(), "c".atom()], type: Types.TUPLE}], type: Types.TUPLE};
    var barList:List<Dynamic> = new List<Dynamic>();
    barList.add(1);
    barList.add(2);
    barList.add(barTuple);

    var rightMap:ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
    rightMap.set("anna".atom(), "food");
    rightMap.set("bar".atom(), barList);
    rightMap.set("baz".atom(), {value: new ObjectMap<Dynamic, Dynamic>(), type: Types.MAP});

    var right:MatchObjectMap = {value: rightMap, type: Types.MAP};

    var matchData:MatchData = matcher.match(left, right, new Map<String, Dynamic>());
    Assert.isTrue(matchData.matched);
  }
}