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
import vm.DefaultKernelTest;
import exec.DefaultTermExecuterTest;
import lang.HashTableAtomsTest;
import code.DefaultApplicationCodeTest;
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
		add(vm.DefaultKernelTest);
		add(exec.DefaultTermExecuterTest);
		add(lang.HashTableAtomsTest);
		add(code.DefaultApplicationCodeTest);
		add(util.StackUtilTest);
	}
}
