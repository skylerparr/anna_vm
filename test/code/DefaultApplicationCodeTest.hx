package code;

import matcher.DefaultMatcher;
import matcher.Matcher;
import lang.Types.Tuple;
import code.ApplicationCode.AccessModifier;
import interp.ExecutionScope;
import lang.MatchValue;
import support.InterpSupport;
import interp.DataStructureInterpreter;
import lang.HashTableAtoms;
import lang.AtomSupport;
import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;
import lang.Types.Atom;
import lang.Types.Tuple;
import lang.Types;

import mockatoo.Mockatoo.*;
using mockatoo.Mockatoo;
using lang.AtomSupport;

class DefaultApplicationCodeTest {

  private var applicationCode: DefaultApplicationCode;
  private var interp: DataStructureInterpreter;
  private var scope: ExecutionScope;
  private var matcher: DefaultMatcher;

  @BeforeClass
  public function beforeClass():Void {
    var atoms: HashTableAtoms = new HashTableAtoms();
    AtomSupport.atoms = atoms;
  }

  @AfterClass
  public function afterClass():Void {
    AtomSupport.atoms = null;
  }

  @Before
  public function setup():Void {
    interp = InterpSupport.getInterpreter();
    scope = mock(ExecutionScope);
    matcher = new DefaultMatcher();

    applicationCode = new DefaultApplicationCode();
    applicationCode.matcher = matcher;
    applicationCode.init();
  }

  @After
  public function tearDown():Void {
    applicationCode = null;
  }

  @Test
  public function shouldDefineAModuleAndFetchIt(): Void {
    var block: MatchValue = interp.decode('{:__block__, {}}', scope);
    var blockDetails: Array<MatchValue> = block.value.value[1].value.value;
    for(i in 0...5) {
      var c: MatchValue = interp.decode('{:add, {:native, :\"lib.BasicMath\"}, {${i}, ${i}}}', scope);
      blockDetails.push(c);
    }
    var args: MatchValue = interp.decode('{arg1, arg2}', scope);

    var result: Tuple = applicationCode.define("Foo".atom(), "dance".atom(), AccessModifier.PUBLIC, args, block);
    Assert.areEqual(result.value[0], "Foo".atom());
    Assert.areEqual(result.value[1], "dance".atom());
    Assert.areEqual(result.value[2], AccessModifier.PUBLIC);
    Assert.areSame(result.value[3], args);
    Assert.areSame(result.value[4], block);

    var paramArms: MatchValue

    var matchValue: MatchValue = applicationCode.getCode("Foo".atom(), "dance".atom(), {value: [1, "foo"], type: Types.TUPLE});
    Assert.isNotNull(matchValue);
    Assert.areEqual(interp.toString(block), interp.toString(matchValue));
  }
}