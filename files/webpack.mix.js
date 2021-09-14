const mix = require('laravel-mix')

mix.postCss('./Resources/Sources/Style/App.css', 'Resources/Public/site.css', [
    require('tailwindcss')('./tailwind.config.js'),
    require('postcss-import'),
    require('autoprefixer')
]);

mix.typeScript("./Resources/Sources/Script/App.ts", "Resources/Public/site.js");

mix.disableNotifications();
mix.extract("Resources/Public/js/vendor.js");

mix.options({
    terser: {
        terserOptions: {
            compress: {
                drop_console: true
            }
        }
    }
});

mix.webpackConfig({
    optimization: {
        usedExports: true,
    }
});