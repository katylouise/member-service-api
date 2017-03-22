# Member Service API
Member Service API is a [Rails 5][rails] application designed to serve ntriple files.

[![License][shield-license]][info-license]


### Contents
<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Requirements](#requirements)
- [Getting Started](#getting-started)
  - [Running the application](#running-the-application)
- [Contributing](#contributing)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Requirements
Member Service API requires the following
* [Ruby 2.3.1][ruby]


## Getting Started
Setup the main application repository:
```bash
git clone https://github.com/ukparliament/member-service-api.git
cd member-service-api
bundle install
cp .env.sample .env
```

Within the `.env` file, you will need to specify the `UKPDS_DATA_ENDPOINT` value. Without this, the application will not run successfully. The

### Running the application
We recommend running the application through docker. With docker installed on your machine, run:
```bash
make build
make dev
```

`make build` creates a docker image on your machine

`make dev` runs the application and attaches the current directory into the docker container. This means updates you make to the views and contollers will be automatically reflected.

## Making Requests
A request can be made to the triple store by passing the query to the response_streamer.  For example,
```
response_streamer(query)
```

Multiple requests can be made in the controller and they will be returned as one response.    For example,
```
response_streamer(query_one)
response_streamer(query_two)
```

The response streamer will append the subsequent response to the first, creating a single response.

## Contributing
If you wish to submit a bug fix or feature, you can create a pull request and it will be merged pending a code review.

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


## License
[Member Service API][member-service-api] is licensed under the [Open Parliament Licence][info-license].

[rails]:              http://rubyonrails.org
[parliament]:         http://www.parliament.uk
[ruby]:               https://www.ruby-lang.org/en/
[member-service-api]: https://github.com/ukparliament/member-service-api

[info-license]:   http://www.parliament.uk/site-information/copyright/open-parliament-licence/
[shield-license]: https://img.shields.io/badge/license-Open%20Parliament%20Licence-blue.svg
