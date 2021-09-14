<?php
class GeneratorOutput {
	private $filename;
	private $path;
	private $content;
	
	/**
	 * @param $filename
	 * @param $path
	 * @param $content
	 */
	public function __construct($filename, $path, $content) {
		$this->filename = $filename;
		$this->path = $path;
		$this->content = $content;
	}
	
	/**
	 * @return mixed
	 */
	public function getFilename() {
		return $this->filename;
	}
	
	/**
	 * @return mixed
	 */
	public function getPath() {
		return $this->path;
	}
	
	/**
	 * @return mixed
	 */
	public function getContent() {
		return $this->content;
	}
	
	public function getFullPath() {
		return sprintf("%s/%s", trim($this->getPath()), trim($this->getFilename()));
	}
}