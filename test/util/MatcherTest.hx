package util;

import lang.Atoms;
import util.Matcher;
import lang.MatchData;
import lang.MatchValue;
import haxe.ds.ObjectMap;
import lang.Types.Tuple;
import lang.Types.Atom;
import lang.Types.LinkedList;
import lang.Types.MatchMap;
import lang.Types;
import lang.MatchType;
import massive.munit.Assert;

class MatcherTest {

    @Test
    public function shouldMatchConstants(): Void {
        var left: MatchValue = getMatcher(1);
        var right: Int = 1;

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);

        var left: MatchValue = getMatcher(1.302948);
        var right: Float = 1.302948;

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);

        var left: MatchValue = getMatcher("foo");
        var right: String = "foo";

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
    }

    @Test
    public function shouldNotMatchContantsThatDontMatch(): Void {
        var left: MatchValue = getMatcher(1);
        var right: String = "foo";

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isFalse(matchData.matched);
    }

    @Test
    public function shouldMatchOnAVariableAndAssignIt(): Void {
        var left: MatchValue = getMatcherAssign("foo");
        var right: Int = 1;

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
        Assert.areEqual(matchData.matchedVars.get("foo"), 1);
    }

    @Test
    public function shouldMatchOnTuple(): Void {
        var left: MatchValue = getComplexMatcher({value: [getMatcher(1), getMatcher("foo"), getMatcher(123)], type: Types.TUPLE});
        var right: Tuple = {value: [1, "foo", 123], type: Types.TUPLE};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
    }

    @Test
    public function shouldNotMatchOnTupleIfNotMatched(): Void {
        var left: MatchValue = getComplexMatcher({value: {value: [getMatcher(1), getMatcher("foo"), getMatcher(123)], type: Types.TUPLE}});
        var right: Tuple = {value: [1, "bar", 123], type: Types.TUPLE};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isFalse(matchData.matched);
    }

    @Test
    public function shouldNotMatchIfBothTypesAreDifferent(): Void {
        var left: MatchValue = getComplexMatcher({value: {value: [getMatcher(1), getMatcher("foo"), getMatcher(123)], type: Types.TUPLE}});
        var right: String = "bar";

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isFalse(matchData.matched);
    }

    @Test
    public function shouldMatchOnTupleAndAssignVariables(): Void {
        var left: MatchValue = getComplexMatcher({value: [getMatcher(1), getMatcherAssign("bar"), getMatcher(123)], type: Types.TUPLE});
        var right: Tuple = {value: [1, "foo", 123], type: Types.TUPLE};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
        Assert.areEqual(matchData.matchedVars.get("bar"), "foo");
    }

    @Test
    public function shouldAssignAllMatchedVariablesInTuple(): Void {
        var left: MatchValue = getComplexMatcher({value: [getMatcherAssign("number"), getMatcherAssign("words"), getMatcherAssign("bigger_number")], type: Types.TUPLE});
        var right: Tuple = {value: [1, "foo", 123], type: Types.TUPLE};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
        Assert.areEqual(matchData.matchedVars.get("number"), 1);
        Assert.areEqual(matchData.matchedVars.get("words"), "foo");
        Assert.areEqual(matchData.matchedVars.get("bigger_number"), 123);
    }

    @Test
    public function shouldAssignEntireTuple(): Void {
        var left: MatchValue = getMatcherAssign("whole_tuple");
        var right: Tuple = {value: [1, "foo", 123], type: Types.TUPLE};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
        var t: Tuple = matchData.matchedVars.get("whole_tuple");
        Assert.areEqual(t.type, Types.TUPLE);
        Assert.areEqual(t.value[0], 1);
        Assert.areEqual(t.value[1], "foo");
        Assert.areEqual(t.value[2], 123);
    }

    @Test
    public function shouldMatchOnAtoms(): Void {
        var left: MatchValue = getMatcher(Atoms.TRUE);
        var right: Atom = Atoms.TRUE;

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
    }

    @Test
    public function shouldNotMatchOnAtomsThatDontMatch(): Void {
        var left: MatchValue = getMatcher(Atoms.TRUE);
        var right: Atom = Atoms.FALSE;

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isFalse(matchData.matched);
        Assert.isNull(matchData.matchedVars);
    }

    @Test
    public function shouldAssignAtom(): Void {
        var left: MatchValue = getMatcherAssign("my_atom");
        var right: Atom = Atoms.TRUE;

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
        Assert.areEqual(right, matchData.matchedVars.get("my_atom"));
    }

    @Test
    public function shouldMatchOnLists(): Void {
        var leftList: List<Dynamic> = new List<Dynamic>();
        leftList.add(getMatcher("2"));
        leftList.add(getMatcher("food"));
        leftList.add(getMatcher(456.45));

        var rightList: List<Dynamic> = new List<Dynamic>();
        rightList.add("2");
        rightList.add("food");
        rightList.add(456.45);

        var left: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftList, type: Types.LIST}};
        var right: LinkedList = {value: rightList, type: Types.LIST};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
    }

    @Test
    public function shouldNotMatchOnListsIfNotMatched(): Void {
        var leftList: List<Dynamic> = new List<Dynamic>();
        leftList.add(getMatcher("2"));
        leftList.add(getMatcher("food"));
        leftList.add(getMatcher(456.45));

        var rightList: List<Dynamic> = new List<Dynamic>();
        rightList.add(2);
        rightList.add("food");
        rightList.add(456.45);

        var left: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftList, type: Types.LIST}};
        var right: LinkedList = {value: rightList, type: Types.LIST};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isFalse(matchData.matched);
    }

    @Test
    public function shouldAssignMatchedVariables(): Void {
        var leftList: List<Dynamic> = new List<Dynamic>();
        leftList.add(getMatcher("2"));
        leftList.add(getMatcherAssign("food"));
        leftList.add(getMatcher(456.45));

        var rightList: List<Dynamic> = new List<Dynamic>();
        rightList.add("2");
        rightList.add("steak");
        rightList.add(456.45);

        var left: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftList, type: Types.LIST}};
        var right: LinkedList = {value: rightList, type: Types.LIST};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
        Assert.areEqual(matchData.matchedVars.get("food"), "steak");
    }

    @Test
    public function shouldAssignList(): Void {
        var left: MatchValue = {type: MatchType.VARIABLE, varName: "whole_list", value: null};

        var rightList: List<Dynamic> = new List<Dynamic>();
        rightList.add("2");
        rightList.add("steak");
        rightList.add(456.45);

        var right: LinkedList = {value: rightList, type: Types.LIST};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);

        var wholeList: List<Dynamic> = matchData.matchedVars.get("whole_list").value;
        Assert.areEqual(wholeList, rightList);
        Assert.areEqual(wholeList.pop(), "2");
        Assert.areEqual(wholeList.pop(), "steak");
        Assert.areEqual(wholeList.pop(), 456.45);
    }

    @Test
    public function shouldAssignHeadAndMatchTailOnAList(): Void {
        var leftListTail: List<Dynamic> = new List<Dynamic>();
        leftListTail.add(getMatcher("2"));
        leftListTail.add(getMatcher(456.45));
        var left: MatchValue = {type: MatchType.HEAD_TAIL, varName: null, value:
        [getMatcherAssign("food"), {value: getComplexMatcher({value: leftListTail, type: Types.LIST})}]};

        var rightList: List<Dynamic> = new List<Dynamic>();
        rightList.add("steak");
        rightList.add("2");
        rightList.add(456.45);

        var right: LinkedList = {value: rightList, type: Types.LIST};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
        Assert.areEqual(matchData.matchedVars.get("food"), "steak");
    }

    @Test
    public function shouldNotMatchTailOnAList(): Void {
        var leftListTail: List<Dynamic> = new List<Dynamic>();
        leftListTail.add(getMatcher("2"));
        leftListTail.add(getMatcher(456.45));
        var left: MatchValue = {type: MatchType.HEAD_TAIL, varName: null, value:
        [getMatcherAssign("food"), {value: getComplexMatcher({value: leftListTail, type: Types.LIST})}]};

        var rightList: List<Dynamic> = new List<Dynamic>();
        rightList.add("steak");
        rightList.add("224");
        rightList.add(456.45);

        var right: LinkedList = {value: rightList, type: Types.LIST};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isFalse(matchData.matched);
        Assert.isNull(matchData.matchedVars);
    }

    @Test
    public function shouldMatchHeadAndTailOnAListAsVariables(): Void {
        var left: MatchValue = {type: MatchType.HEAD_TAIL, varName: null, value:
        [getMatcherAssign("head"), {value: getMatcherAssign("tail"), type: Types.LIST}]};

        var rightList: List<Dynamic> = new List<Dynamic>();
        rightList.add("steak");
        rightList.add("224");
        rightList.add(456.45);

        var right: LinkedList = {value: rightList, type: Types.LIST};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
        Assert.areEqual(matchData.matchedVars.get("head"), "steak");
        var tailList: List<Dynamic> = matchData.matchedVars.get("tail").value;
        Assert.areEqual(tailList.pop(), "224");
        Assert.areEqual(tailList.pop(), 456.45);
    }

    @Test
    public function shouldMatchHeadAndAssignTailOnAList(): Void {
        var left: MatchValue = {type: MatchType.HEAD_TAIL, varName: null, value:
        [getMatcher("steak"), {value: getMatcherAssign("tail"), type: Types.LIST}]};

        var rightList: List<Dynamic> = new List<Dynamic>();
        rightList.add("steak");
        rightList.add("224");
        rightList.add(456.45);

        var right: LinkedList = {value: rightList, type: Types.LIST};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
        var tailList: List<Dynamic> = matchData.matchedVars.get("tail").value;
        Assert.areEqual(tailList.pop(), "224");
        Assert.areEqual(tailList.pop(), 456.45);
    }

    @Test
    public function shouldMatchNestedComplexStructures(): Void {
        var tupleMatch: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: [getMatcher(1), getMatcherAssign("bar"), getMatcher(123)], type: Types.TUPLE}};

        var leftList: List<Dynamic> = new List<MatchValue>();
        leftList.add(getMatcher("2"));
        leftList.add(getMatcherAssign("food"));
        leftList.add(tupleMatch);

        var rightTuple: Tuple = {value: [1, "foo", 123], type: Types.TUPLE};
        var rightList: List<Dynamic> = new List<Dynamic>();
        rightList.add("2");
        rightList.add("steak");
        rightList.add(rightTuple);

        var left: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftList, type: Types.LIST}};
        var right: LinkedList = {value: rightList, type: Types.LIST};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
        var keyCount: Int = 0;
        for(i in matchData.matchedVars.keys()) {
            keyCount++;
        }
        Assert.areEqual(2, keyCount);
        Assert.areEqual(matchData.matchedVars.get("food"), "steak");
        Assert.areEqual(matchData.matchedVars.get("bar"), "foo");
    }

    @Test
    public function shouldNotMatchNestedComplexStructures(): Void {
        var tupleMatch: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: [getMatcher("1"), getMatcherAssign("bar"), getMatcher(123)], type: Types.TUPLE}};

        var leftList: List<Dynamic> = new List<MatchValue>();
        leftList.add(getMatcher("2"));
        leftList.add(getMatcherAssign("food"));
        leftList.add(tupleMatch);

        var rightTuple: Tuple = {value: [1, "foo", 123], type: Types.TUPLE};
        var rightList: List<Dynamic> = new List<Dynamic>();
        rightList.add("2");
        rightList.add("steak");
        rightList.add(rightTuple);

        var left: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftList, type: Types.LIST}};
        var right: LinkedList = {value: rightList, type: Types.LIST};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isFalse(matchData.matched);
    }

    @Test
    public function shouldMatchKeysAndValuesInAMap(): Void {
        var foo: Atom = {type: Types.ATOM, value: "foo"};
        var cat: Atom = {type: Types.ATOM, value: "cat"};

        var leftMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        leftMap.set(getMatcher(foo), getMatcher("bar"));
        leftMap.set(getMatcher(cat), getMatcher("fluffer"));

        var rightMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        rightMap.set(foo, "bar");
        rightMap.set(cat, "fluffer");

        var left: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftMap, type: Types.MAP}};
        var right: MatchMap = {value: rightMap, type: Types.MAP};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
    }

    @Test
    public function shouldNotMatchKeysAndValuesInAMap(): Void {
        var foo: Atom = {type: Types.ATOM, value: "foo"};
        var cat: Atom = {type: Types.ATOM, value: "cat"};

        var leftMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        leftMap.set(getMatcher(foo), getMatcher("bar"));
        leftMap.set(getMatcher(cat), getMatcher("fluffery"));

        var rightMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        rightMap.set(foo, "bar");
        rightMap.set(cat, "fluffer");

        var left: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftMap, type: Types.MAP}};
        var right: MatchMap = {value: rightMap, type: Types.MAP};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isFalse(matchData.matched);
    }

    @Test
    public function shouldMatchKeysAndValuesWithVarsInAMap(): Void {
        var foo: Atom = {type: Types.ATOM, value: "foo"};
        var cat: Atom = {type: Types.ATOM, value: "cat"};

        var leftMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        leftMap.set(getMatcher(foo), getMatcherAssign("foo"));
        leftMap.set(getMatcher(cat), getMatcher("fluffer"));

        var rightMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        rightMap.set(foo, "bar");
        rightMap.set(cat, "fluffer");

        var left: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftMap, type: Types.MAP}};
        var right: MatchMap = {value: rightMap, type: Types.MAP};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);

        Assert.areEqual(matchData.matchedVars.get("foo"), "bar");
    }

    @Test
    public function shouldPatternMatchMapKeys(): Void {
        var leftList: List<Dynamic> = new List<Dynamic>();
        leftList.add(getMatcher("2"));
        leftList.add(getMatcherAssign("food"));
        leftList.add(getMatcher(456.45));
        var leftMatchValue: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftList, type: Types.LIST}};

        var leftMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        leftMap.set(leftMatchValue, getMatcherAssign("fluffer"));

        var rightList: List<Dynamic> = new List<Dynamic>();
        rightList.add("2");
        rightList.add("steak");
        rightList.add(456.45);

        var rightMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        var right: LinkedList = {value: rightList, type: Types.LIST};
        rightMap.set(right, "bar");

        var left: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftMap, type: Types.MAP}};
        var right: MatchMap = {value: rightMap, type: Types.MAP};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isTrue(matchData.matched);
        Assert.areEqual(matchData.matchedVars.get("food"), "steak");
    }

    @Test
    public function shouldNotPatternMatchNotMatchableMapKeys(): Void {
        var leftList: List<Dynamic> = new List<Dynamic>();
        leftList.add(getMatcher("11"));
        leftList.add(getMatcherAssign("food"));
        leftList.add(getMatcher(456.45));
        var leftMatchValue: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftList, type: Types.LIST}};

        var leftMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        leftMap.set(leftMatchValue, getMatcherAssign("fluffer"));

        var rightList: List<Dynamic> = new List<Dynamic>();
        rightList.add("2");
        rightList.add("steak");
        rightList.add(456.45);

        var rightMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        var right: LinkedList = {value: rightList, type: Types.LIST};
        rightMap.set(right, "bar");

        var left: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftMap, type: Types.MAP}};
        var right: MatchMap = {value: rightMap, type: Types.MAP};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isFalse(matchData.matched);
    }

    @Test
    public function shouldNotMatchVariableKeys(): Void {
        var foo: Atom = {type: Types.ATOM, value: "foo"};
        var cat: Atom = {type: Types.ATOM, value: "cat"};

        var leftMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        leftMap.set(getMatcherAssign("foo"), getMatcher("bar"));
        leftMap.set(getMatcher(cat), getMatcher("fluffer"));

        var rightMap: ObjectMap<Dynamic, Dynamic> = new ObjectMap<Dynamic, Dynamic>();
        rightMap.set(foo, "bar");
        rightMap.set(cat, "fluffer");

        var left: MatchValue = {type: MatchType.COMPLEX, varName: null, value: {value: leftMap, type: Types.MAP}};
        var right: MatchMap = {value: rightMap, type: Types.MAP};

        var matchData: MatchData = Matcher.match(left, right, new Map<String, Dynamic>());
        Assert.isFalse(matchData.matched);
    }

    private function getComplexMatcher(value:Dynamic):MatchValue {
        return {type: MatchType.COMPLEX, varName: null, value: value};
    }

    private function getMatcher(value:Dynamic):MatchValue {
        return {type: MatchType.CONSTANT, varName: null, value: value};
    }

    private function getMatcherAssign(varName: String):MatchValue {
        return {type: MatchType.VARIABLE, varName: varName, value: null};
    }
}