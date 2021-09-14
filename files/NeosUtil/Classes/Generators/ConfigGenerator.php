<?php
class ConfigGenerator extends AbstractGenerator {
	public function generate(): GeneratorOutput {
		$filename = $this->getConfig()->getName() . ".fusion";
		$path = "Resources/Private/Fusion/Components";
		
		$data = ["id" => $this->getConfig()->getName(), "namespace" => projectNamespace()];
		
		$content = parseTemplate("fusion", $data);
		
		return new GeneratorOutput($filename, $path, $content);
	}
}