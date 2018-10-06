import massive.munit.TestSuite;

import code.DefaultApplicationCodeTest;
import core.ObjectFactoryTest;
import core.ThreadSafeProcessManagerTest;
import exec.DefaultTermExecuterTest;
import interp.DefaultDataStructureInterpreterTest;
import interp.StringMapExecutionScopeTest;
import lang.HashTableAtomsTest;
import matcher.DefaultMatcherTest;
import util.StackUtilTest;
import vm.DefaultKernelTest;
import vm.DefaultSystemTest;
import vm.SimpleProcessTest;
import vm.terms.VMAtomTest;
import vm.terms.VMFloatTest;
import vm.terms.VMIntegerTest;
import vm.terms.VMSmallUTF8AtomTest;
import vm.terms.VMStringTest;
import vm.terms.VMUTF8AtomTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(code.DefaultApplicationCodeTest);
		add(core.ObjectFactoryTest);
		add(core.ThreadSafeProcessManagerTest);
		add(exec.DefaultTermExecuterTest);
		add(interp.DefaultDataStructureInterpreterTest);
		add(interp.StringMapExecutionScopeTest);
		add(lang.HashTableAtomsTest);
		add(matcher.DefaultMatcherTest);
		add(util.StackUtilTest);
		add(vm.DefaultKernelTest);
		add(vm.DefaultSystemTest);
		add(vm.SimpleProcessTest);
		add(vm.terms.VMAtomTest);
		add(vm.terms.VMFloatTest);
		add(vm.terms.VMIntegerTest);
		add(vm.terms.VMSmallUTF8AtomTest);
		add(vm.terms.VMStringTest);
		add(vm.terms.VMUTF8AtomTest);
	}
}
