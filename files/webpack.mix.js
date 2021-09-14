const mix = require('laravel-mix')

mix.postCss('./Resources/Source/Style/App.css', 'Resources/Public/Styles/app.css', [
    require('tailwindcss')('./tailwind.config.js'),
    require('postcss-import'),
    require('autoprefixer')
]);

mix.typeScript("./Resources/Source/Script/App.ts", "Resources/Public/Javascript/site.js");

mix.disableNotifications();
mix.extract("Resources/Public/Javascript/vendor.js");

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