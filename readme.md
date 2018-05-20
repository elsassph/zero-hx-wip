# WIP Zero-hx example

Goal: zero-config, full stack, Haxe web app development.

## Implemented

* Custom router
  * Routes autodetection from filesystem
  * Generic core, React implementation
* Client Webpack 4 build
  * Dev with hot-reload
  * Routes splitting (including CSS)
  * Prod all minified
  * CSS / post-css
  * Optional files hashing for aggressive caching
  * Static HTML generation
* Express server
  * URL rewiting
  * Static files

## Plan

* [ ] Create NPM library to encapsulate the build process (see `/zero-hx`)
* [ ] Create NPM library to generate new projects (`create-haxe-app`?)
* [ ] Lighter server for deployment (micro? koa?)
* [ ] Caching policy for routes data
* [ ] Server-side rendering
* [ ] Server ETAGs for dynamic pages
* [ ] Look into Docker deployment
* [ ] Complete deployment guide

## Project structure (goal)

* `package.json`: Includes tool options (default page title, hashing...)
* `build.hxml`: Haxe compiler options (and code completion). Can be built directly but won't run.
* `src/Page.hx`: Page wrapper.
* `src/route/Index.hx`: Home page
* `src/route/Error.hx`: Catch-all page it no route matches
* `src/route/<xyz>.hx`: Other routes (`/<zyw>/*`)
* `public/`: Static files not provided by React (`favicon`, fonts...)
* `dist/`: Build output

## Development

    npm install
    npm run dev

Webpack dev server will serve `/public` and your app from memory. Just edit and changes will be
automatically refreshed.

## Static build

    npm run static
    npm run start

Project will be created on disk, non-minified, and you can run the Express server.

    npm run build

Produces a release build for production deployment.

## Deployment

A static app is relatively simple to deploy: take `dist/public` and put behind a server which
can do basic URL rewriting (serve static files and return the `index.html` page for other queries).

Currently that's what the build process create, including a simple Express server under `dist/`.

For very simple Node.js deployment I tried:

* [Heroku](https://heroku.com) - it didn't fit this project because you have to `git push` your
  project, which is a problem for languages with a build step, and Haxe didn't want to compile
  in the provided environment. No luck for me - maybe revisit with Docker?

* [Zeit.co's Now](https://zeit.co/now) - as advertised it just worked; _Now_ lets you push your
  compiled project as is, so `now ./dist` will push your Node.js app in seconds.

_Now_ seem to be a great solution to get something out for testing or small projects. You'd
want to look into adding a proxy/CDN as described in the
[Cloudflare guide](https://zeit.co/docs/guides/how-to-use-cloudflare).
For larger projects, I'll expect that you will have either relevant experience, or support from
competent devops persons who will get your app on AWS or Azure :)
