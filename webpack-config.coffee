path = require('path')
webpack = require('webpack')

module.exports = {
	cache: true
	entry: {
		app: path.join(__dirname, 'src', 'index.coffee')
	}
	output: {
		path: path.join(__dirname, 'dist', 'browser')
		filename: 'wrap-client.js'
	}
	module: {
		preLoaders: [
			{
				test: /\.coffee$/
				exclude: /node_modules/
				loader: 'coffeelint-loader'
			}
		]
		loaders: [
			{ test: /\.coffee$/, loaders: ['coffee-loader'] }
		]
	}
	coffeelint: {
		configFile: './coffeelint.json'
	}
	resolve: {
		root: __dirname
		extensions: ['', '.js', '.coffee']
		modulesDirectories: ['.', 'src', 'node_modules']
	}
}
