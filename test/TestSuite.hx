import massive.munit.TestSuite;

import core.ObjectFactoryTest;
import core.ThreadSafeProcessManagerTest;
import util.StackUtilTest;
import interp.StringMapExecutionScopeTest;
import interp.DefaultDataStructureInterpreterTest;
import code.DefaultApplicationCodeTest;
import matcher.DefaultMatcherTest;
import lang.HashTableAtomsTest;
import vm.terms.VMIntegerTest;
import vm.terms.VMStringTest;
import vm.terms.VMSmallUTF8AtomTest;
import vm.terms.VMFloatTest;
import vm.terms.VMAtomTest;
import vm.terms.VMUTF8AtomTest;
import vm.DefaultSystemTest;
import vm.SimpleProcessTest;
import vm.DefaultKernelTest;
import exec.DefaultTermExecuterTest;

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
		add(core.ThreadSafeProcessManagerTest);
		add(util.StackUtilTest);
		add(interp.StringMapExecutionScopeTest);
		add(interp.DefaultDataStructureInterpreterTest);
		add(code.DefaultApplicationCodeTest);
		add(matcher.DefaultMatcherTest);
		add(lang.HashTableAtomsTest);
		add(vm.terms.VMIntegerTest);
		add(vm.terms.VMStringTest);
		add(vm.terms.VMSmallUTF8AtomTest);
		add(vm.terms.VMFloatTest);
		add(vm.terms.VMAtomTest);
		add(vm.terms.VMUTF8AtomTest);
		add(vm.DefaultSystemTest);
		add(vm.SimpleProcessTest);
		add(vm.DefaultKernelTest);
		add(exec.DefaultTermExecuterTest);
	}
}
