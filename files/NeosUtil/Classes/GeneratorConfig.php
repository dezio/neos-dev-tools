<?php

class GeneratorConfig {
	private $name;
	private $siteDir;
	
	/**
	 * @return mixed
	 */
	public function getName() {
		return $this->name;
	}
	
	/**
	 * @return mixed
	 */
	public function getSiteDir() {
		return $this->siteDir;
	}
	
	/**
	 * @param $name
	 * @param $siteDir
	 */
	public function __construct($name, $siteDir) {
		$this->name = $name;
		$this->siteDir = $siteDir;
	}
	
	
}