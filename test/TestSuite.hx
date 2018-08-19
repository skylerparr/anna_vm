import massive.munit.TestSuite;

import core.ObjectFactoryTest;
import matcher.DefaultMatcherTest;
import interp.StringMapExecutionScopeTest;
import interp.DefaultDataStructureInterpreterTest;
import vm.terms.VMFloatTest;
import vm.terms.VMIntegerTest;
import vm.terms.VMSmallUTF8AtomTest;
import vm.terms.VMStringTest;
import vm.terms.VMAtomTest;
import vm.terms.VMUTF8AtomTest;
import vm.SimpleProcessTest;
import vm.DefaultSystemTest;
import exec.DefaultTermExecuterTest;
import lang.HashTableAtomsTest;
import util.StackUtilTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(core.ObjectFactoryTest);
		add(matcher.DefaultMatcherTest);
		add(interp.StringMapExecutionScopeTest);
		add(interp.DefaultDataStructureInterpreterTest);
		add(vm.terms.VMFloatTest);
		add(vm.terms.VMIntegerTest);
		add(vm.terms.VMSmallUTF8AtomTest);
		add(vm.terms.VMStringTest);
		add(vm.terms.VMAtomTest);
		add(vm.terms.VMUTF8AtomTest);
		add(vm.SimpleProcessTest);
		add(vm.DefaultSystemTest);
		add(exec.DefaultTermExecuterTest);
		add(lang.HashTableAtomsTest);
		add(util.StackUtilTest);
	}
}
