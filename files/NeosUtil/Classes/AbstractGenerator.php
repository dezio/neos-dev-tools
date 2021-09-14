<?php
abstract class AbstractGenerator {
	/** @var NeosGenerator */
	protected $neosGenerator;
	
	protected function getConfig() {
		return $this->neosGenerator->getConfig();
	}
	
	protected function mergeConfig($arr = []) {
		$data = ["id" => $this->getConfig()->getName(), "namespace" => projectNamespace()];
		return array_merge($data, $arr);
	}
	
	/**
	 * @param NeosGenerator $neosGenerator
	 */
	public function __construct(NeosGenerator $neosGenerator) { $this->neosGenerator = $neosGenerator; }
	
	abstract function generate(): GeneratorOutput;
}