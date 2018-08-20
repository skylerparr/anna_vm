package vm;

import massive.munit.Assert;


class DefaultKernelTest {

  private var kernel: DefaultKernel;

  @Before
  public function setup():Void {
    kernel = new DefaultKernel();
    kernel.init();
  }

  @After
  public function tearDown():Void {
    kernel.dispose();
    kernel = null;
  }

  @Test
  public function shouldSpawnNewProcess(): Void {

  }

}