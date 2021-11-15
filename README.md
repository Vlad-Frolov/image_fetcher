# image_fetcher
Here is a simple and compact solution using Threads and OpenUri. This solution solves all default tasks connected with downloading images. Some specs have been written to verify work with files and images. Webmock has been used to Stub requests in Rspec Tests.

# Ruby version
2.7.1

# Usage
1. `git clone https://github.com/Vlad-Frolov/image_fetcher.git`
2. `bundle`
3. `cd lib`
4. `./image_fetcher.rb path_to_file`

Example of usage: `./image_fetcher.rb ../testfile 2` or `./image_fetcher.rb ../testfile` (8 batches will be used by default)

# Demo
https://www.youtube.com/watch?v=dUgnJacsJjE&ab_channel=VladislavFrolov
