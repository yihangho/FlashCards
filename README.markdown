# FlashCards

FlashCards is a web application that facilitates the learning of new vocabulary by using, unsurprisingly, flash cards.

## Deployment

FlashCards is a Ruby on Rails application. The hard requirements for running FlashCards are:

1. Ruby 2.1.5
2. Ability to install Ruby Gems (via Bundler).
3. PostgreSQL

It is recommended to use Heroku: simply push this repository to Heroku and you are good to go.

## Optional Configurations

### Pronunciation & Dictionaries
FlashCards can pronounce words added. This is achieve by two means: the Web Speech API and dictionaries. Web Speech API will be used if it is supported by the client. At the moment, support for Web Speech API is sporadic - only Chrome and Safari support Web Speech API. To overcome this shortcoming, dictionary can be used. When requested, FlashCards can query one of the two supported dictionaries (Cambridge and Merriam-Webster) for pronunciation for certain words in the form of audio file. Since neither of these dictionaries has the audio files for _all_ English words, it is recommended to have both enabled to maximize coverage.

#### Cambridge
1. Request an API key from [Cambridge Dictionaries Online](http://dictionary-api.cambridge.org/index.php/request-api-key).
2. Set the `CAMBRIDGE_API_KEY` environment variable to the API key given.

#### Merriam-Webster
1. Request an API key from [Merriam-Webster Developer Center](http://www.dictionaryapi.com/register/index.htm).
2. Set the `MERRIAM_WEBSTER_API_KEY` environment variable to the API key given.

#### Redis Cache
Querying the dictionaries is slow. As a result, it does not make sense to query the same thing twice, especially because the pronunciation audio files do not change frequently, if at all. Hence, it is recommended to enable Redis to perform some caching if the dictionaries are used.

To enable Redis, set the `REDIS_URL` environment variable to point to your Redis instance. Note that if your Redis instance is password-protected, the URL should include the username and/or password.

### ElasticSearch
'nuff said. Set `ELASTIC_SEARCH_PATH` to point to your ElasticSearch instance. Again, it should include your ElasticSearch username and/or password, if necessary. Also set `ELASTIC_SEARCH_INDEX` to be the index in which the cards should be indexed.
