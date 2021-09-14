<?php

class FusionGenerator extends AbstractGenerator {
	public function generate(): GeneratorOutput {
		$filename = sprintf("%s.fusion", $this->getConfig()->getName());
		$path = "Resources/Private/Fusion/Components";
		
		$content = parseTemplate("fusion", $this->mergeConfig());
		
		return new GeneratorOutput($filename, $path, $content);
	}
}