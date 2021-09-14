<?php

class NeosGenerator {
	private $config;
	private $generatorClasses = [
		FusionGenerator::class,
		NodeTypeConfigGenerator::class,
		FluidTemplateGenerator::class
	];
	
	/**
	 * @param $config
	 */
	public function __construct(GeneratorConfig $config) {
		$this->config = $config;
	}
	
	/**
	 * @return GeneratorConfig
	 */
	public function getConfig(): GeneratorConfig {
		return $this->config;
	}
	
	public function generate() {
		/** @var AbstractGenerator[] $instances */
		$instances = [];
		foreach ($this->generatorClasses as $class) {
			$instances[] = new $class($this);
		} // foreach end
		
		$outputs = [];
		foreach ($instances as $instance) {
			$outputs[] = $instance->generate();
		} // foreach end
		
		foreach ($outputs as $output) {
			$path = projectBaseDir() . "/" . $output->getFullPath();
			ensureDirExists(dirname($path));
			if (!file_exists($path)) {
				file_put_contents($path, $output->getContent());
			} // if end
			echo $path . PHP_EOL;
			echo "=====" . PHP_EOL;
			echo $output->getContent() . PHP_EOL;
			echo "=====" . PHP_EOL;
		} // foreach end
	}
}