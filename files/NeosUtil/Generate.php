<?php

function rglob($pattern, $flags = 0) {
	$files = glob($pattern, $flags);
	foreach (glob(dirname($pattern).'/*', GLOB_ONLYDIR|GLOB_NOSORT) as $dir) {
		$files = array_merge($files, rglob($dir.'/'.basename($pattern), $flags));
	}
	return $files;
}

foreach(rglob(__DIR__ . "/Classes/*.php") as $file) {
	require_once $file;
}

if(!function_exists("projectNamespace") || empty(projectNamespace())) {
	echo "Unable to determine projectNamespace" . PHP_EOL;
	die();
}

echo "Project namespace: " . projectNamespace() . PHP_EOL;
$name = $argv[1];
echo "Component name: $name" . PHP_EOL;

if(!ctype_upper(substr($name, 0, 1))) {
	echo "Name should start with an uppercase char" . PHP_EOL;
	die();
}

$config = new GeneratorConfig($name, projectBaseDir());
$generator = new NeosGenerator($config);
$generator->generate();