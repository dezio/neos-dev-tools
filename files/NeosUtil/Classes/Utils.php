<?php

function projectBaseDir() {
	return $_SERVER["PROJ_DIR"] ?? getcwd();
}

function projectNamespace() {
	return file_get_contents(projectBaseDir() . "/.project-namespace");
}

function ensureDirExists($dir) {
	if(!file_exists($dir)) {
		if (!mkdir($dir, 0777, true) && !is_dir($dir)) {
			throw new \RuntimeException(sprintf('Directory "%s" was not created', $dir));
		} // if end
	} // if end
}

function parseTemplate($name, $data) {
	ob_start();
	include __DIR__ . "/../templates/$name.php";
	return ob_get_clean();
}