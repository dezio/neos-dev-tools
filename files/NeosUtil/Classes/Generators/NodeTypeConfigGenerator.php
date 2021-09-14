<?php
class NodeTypeConfigGenerator extends AbstractGenerator {
	public function generate(): GeneratorOutput {
		$filename = sprintf("NodeTypes.%s.yaml", $this->getConfig()->getName());
		$path = "Configuration";
		
		$content = parseTemplate("yaml", $this->mergeConfig());
		
		return new GeneratorOutput($filename, $path, $content);
	}
}