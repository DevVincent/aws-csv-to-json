const { CleanWebpackPlugin } = require('clean-webpack-plugin')
const SriPlugin = require('webpack-subresource-integrity')
const path = require('path')
const webpack = require('webpack')
const MiniCSSExtractPlugin = require('mini-css-extract-plugin')
const HTMLWebpackPlugin = require('html-webpack-plugin')
const TerserJSPlugin = require('terser-webpack-plugin')
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin')
const terraformState = require('../terraform-state.json')
const ROOT = process.cwd()
const SHARED = path.resolve(ROOT, 'src')
const SRC = path.resolve(ROOT, 'src/client')
const BUILD = path.resolve(ROOT, 'build/client')
const PRODUCTION = process.env.NODE_ENV === 'production'
const BUILD_STAGE = process.env.BUILD_STAGE

const DEVELOPMENT = 'development'
const API_URL = BUILD_STAGE === DEVELOPMENT
    ? ''
  : `https://${terraformState.api_endpoint_domain}`

const plugins = [
  new webpack.EnvironmentPlugin({
    API_URL,
    BUILD_STAGE: DEVELOPMENT
  })
]

if (PRODUCTION) {
  plugins.unshift(
    new CleanWebpackPlugin(),
    new MiniCSSExtractPlugin({
      filename: '[name].[chunkhash].css'
    })
  )
  plugins.push(
    new SriPlugin({
      enabled: true,
      hashFuncNames: ['sha512']
    })
  )
} else {
  plugins.unshift(
    new webpack.HotModuleReplacementPlugin()
  )
}

const cssModules =
  [
    [/src\/client\/js/, true, /\.scss$/, 'sass'],
    [/src\/client\/scss/, false, /\.scss$/, 'sass'],
    [/node_modules/, false, /\.scss$/, 'sass'],
    [/node_modules/, false, /\.css$/, 'css']
  ].map(([include, modules, test, loader]) => { // eslint-disable-line max-lines-per-function
    const config = [{
      loader: 'css-loader',
      options: {
        modules,
        sourceMap: true
      }
    }]

    if (!PRODUCTION) {
      config.unshift('style-loader')
    }

    if (loader !== 'css') {
      config.push(...[{
        loader: 'postcss-loader',
        options: {
          postcssOptions: {
            plugins: () => [
              require('postcss-preset-env')({ // eslint-disable-line global-require
                stage: 4
              })
            ]
          },
          sourceMap: true
        }
      }, 'resolve-url-loader', {
        loader: `${loader}-loader`,
        options: {
          sourceMap: true
        }
      }])
    }

    return {
      include,
      test,
      use: PRODUCTION ? [MiniCSSExtractPlugin.loader, ...config] : config
    }
  })

// const devModules = PRODUCTION ? [] : ['react-hot-loader/patch']

module.exports = {
  context: SRC,
  devServer: {
    compress: true,
    contentBase: `${BUILD}/client/`,
    disableHostCheck: true,
    historyApiFallback: true,
    hot: true,
    hotOnly: true,
    http2: true,
    https: {
      ca: path.resolve(ROOT, 'infrastructure/ssl-certs/localhost/chain.pem'),
      cert: path.resolve(ROOT, 'infrastructure/ssl-certs/localhost/cert.pem'),
      key: path.resolve(ROOT, 'infrastructure/ssl-certs/localhost/key.pem')
    },
    inline: true,
    open: true,
    port: 4000,
    proxy: {
      '/api': {
        secure: false,
        target: `https://localhost:3000/${BUILD_STAGE}`
      }
    },
    publicPath: '/'
  },
  devtool: PRODUCTION ? false : 'source-map',
  entry: {
    app: [
      'core-js/stable',
      'regenerator-runtime/runtime',
      './js/app',
      './scss/app'
    ]
  },
  mode: PRODUCTION ? 'production' : 'development',
  module: {
    rules: [{
      include: /font/,
      test: /\.(eot|woff2?|ttf|svg)/,
      use: [{
        loader: 'file-loader',
        options: {
          name: 'asset/font/[name].[ext]?[contenthash]'
        }
      }]
    }, {
      include: /img/,
      test: /\.(jpg|png|svg|gif)/,
      use: [{
        loader: 'file-loader',
        options: {
          name: 'asset/img/[name].[ext]?[contenthash]'
        }
      }, 'img-loader']
    }, {
      include: [
        SRC,
        /@hellofiremind/
      ],
      test: /\.jsx?/,
      use: ['babel-loader']
    }, {
      test: /\.yml$/,
      use: ['json-loader', 'yaml-loader']
    }, {
      test: /\.worker\.js$/,
      use: ['worker-loader', 'babel-loader']
    }, {
      test: /\.css$/,
      use: ['style-loader', 'css-loader']
    }, {
      include: /template/,
      test: /\.html$/,
      use: ['raw-loader']
    }].concat(cssModules)
  },
  optimization: {
    minimizer: PRODUCTION ? [new TerserJSPlugin(), new OptimizeCSSAssetsPlugin()] : [],
    runtimeChunk: 'single',
    splitChunks: {
      cacheGroups: {
        vendor: {
          name (module) {
            const packageName = module.context.match(/[\\/]node_modules[\\/](.*?)([\\/]|$)/)[1]

            return `npm.${packageName.replace('@', '')}`
          },
          test: /[\\/]node_modules[\\/]/
        }
      },
      chunks: 'all',
      maxInitialRequests: Infinity,
      minSize: 0
    }
  },
  output: {
    chunkFilename: '[name].bundle.js',
    crossOriginLoading: 'anonymous',
    filename: '[name].[contenthash].js',
    globalObject: 'this',
    path: `${BUILD}`,
    publicPath: '/'
  },
  plugins: [
    new HTMLWebpackPlugin({
      filename: 'index.html',
      hash: true,
      inject: false,
      minify: PRODUCTION ? { collapseWhitespace: true, html5: true } : false,
      template: './html'
    }),
    ...plugins
  ],
  resolve: {
    alias: {
      action: `${SRC}/js/action`,
      base: process.cwd(),
      common: `${SHARED}/common`,
      config: `${SRC}/config`,
      constant: `${SRC}/js/constant`,
      data: `${SRC}/data`,
      font: `${SRC}/font`,
      helper: `${SRC}/js/helper`,
      html: `${SRC}/html`,
      img: `${SRC}/img`,
      js: `${SRC}/js`,
      json: `${SRC}/json`,
      'react-dom': '@hot-loader/react-dom',
      scss: `${SRC}/scss`,
      view: `${SRC}/js/view`
    },
    extensions: ['.html', '.js', '.jsx', '.json', '.scss']
  }
}
