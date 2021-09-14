<?php
class FluidTemplateGenerator extends AbstractGenerator {
	public function generate(): GeneratorOutput {
		$filename = sprintf("%s.html", $this->getConfig()->getName());
		$path = "Resources/Private/Templates/Components/";
		
		$content = parseTemplate("template", $this->mergeConfig());
		
		return new GeneratorOutput($filename, $path, $content);
	}
}