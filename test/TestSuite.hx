import massive.munit.TestSuite;

import core.ObjectFactoryTest;
import vm.DefaultByteCodeInterpreterTest;
import vm.terms.VMAtomTest;
import vm.terms.VMFloatTest;
import vm.terms.VMIntegerTest;
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

		add(core.ObjectFactoryTest);
		add(vm.DefaultByteCodeInterpreterTest);
		add(vm.terms.VMAtomTest);
		add(vm.terms.VMFloatTest);
		add(vm.terms.VMIntegerTest);
		add(vm.terms.VMStringTest);
		add(vm.terms.VMUTF8AtomTest);
	}
}
