=begin
/*

The MIT License (MIT)

Copyright (c) 2014 Zhussupov Zhassulan zhzhussupovkz@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/
=end

require "net/http"
require "net/https"
require "openssl"
require "json"
require "digest"

#GroovesharkApi - simple class for working with Grooveshark Public API
class GroovesharkApi

  def initialize key, secret
    @key, @secret = key, secret
    @api_url = 'https://api.grooveshark.com/ws3.php'
    @session_id = nil
  end

  #create hash
  def generate_hash key, message
    OpenSSL::HMAC.hexdigest('md5', key, message)
  end

  #send request
  def send_request method, params = {}
    header = { 'wsKey' => @key, 'sessionID' => @session_id }
    params = { 'method' => method, 'parameters' => params, 'header' => header }
    post_data = params.to_json
    sig = generate_hash @key, post_data
    url = @api_url + "?sig=#{sig}"
    uri = URI.parse url
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.request_uri)
    req.body = params
    res = http.request(req)
    if res.code == "200"
      data = res.body
      result = JSON.parse(data)
    else
      puts "Invalid getting data from server"
      exit
    end
  end

  #Add songs to a user's library. 
  #Song metadata should be spread across all 3 params. 
  #albumIDs[0] should be the respective albumID for songIDs[0] and same with artistIDs.
  def add_user_library_songs song_id, album_id, artist_id
    params = { 'songIDs' => song_id, 'albumIDs' => album_id, 'artistIDs' => artist_id }
    send_request 'addUserLibrarySongs', params
  end

  #Get user library songs. 
  #Requires an authenticated session.
  def get_user_library_songs limit, page
    params = { 'limit' => limit, 'page' => page }
    send_request 'getUserLibrarySongs', params
  end

  #Add songs to a user's library. 
  #Songs should be an array of objects representing each song with keys: songID, albumID, artistID, trackNum.
  def add_user_library_song_ex songs = {}
    params = { 'songs' => songs }
    send_request 'addUserLibrarySongsEx', params
  end

  #Remove songs from a user's library.
  def remove_user_library_songs song_id, album_id, artist_id
    params = { 'songIDs' => song_id, 'albumIDs' => album_id, 'artistIDs' => artist_id }
    send_request 'removeUserLibrarySongs', params
  end

  #Get subscribed playlists of the logged-in user. 
  #Requires an authenticated session.
  def get_users_playlists_subscribed
    send_request 'getUserPlaylistsSubscribed'
  end

  #Get playlists of the logged-in user. Requires an authenticated session.
  def get_user_playlists
    send_request 'getUserPlaylists'
  end

  #Get user favorite songs. Requires an authenticated session.
  def get_user_favorite_songs
    send_request 'getUserFavoriteSongs'
  end

  #Remove a set of favorite songs for a user. 
  #Must provide a logged-in sessionID.
  def remove_user_favorite_songs song_id
    params = { 'songIDs' => song_id }
  end

  #Logout a user using an established session.
  def logout
    send_request 'logout'
  end

  #Get logged-in user info from sessionID
  def get_user_info
    send_request 'getUserInfo'
  end

  #Get logged-in user subscription info. 
  #Returns type of subscription and either dateEnd or recurring.
  def get_user_subscription_details
    send_request 'getUserSubscriptionDetails'
  end

  #Add a favorite song for a user.
  #Must provide a logged-in sessionID.
  def add_user_favorite_song song_id
    params = { 'songID' => song_id }
    send_request 'addUserFavoriteSong', params
  end

  #Subscribe to a playlist for the logged-in user. 
  #Requires an authenticated session.
  def subscribe_playlist playlist_id
    params = { 'playlistID' => playlist_id }
    send_request 'subscribePlaylist', params
  end

  #Unsubscribe from a playlist for the logged-in user. 
  #Requires an authenticated session.
  def unsubscribe_playlist playlist_id
    params = { 'playlistID' => playlist_id }
    send_request 'unsubscribePlaylist', params
  end

  #Get country from IP. 
  #If an IP is omitted, it will use the request's IP.
  def get_country ip
    params = { 'ip' => id }
    send_request 'getCountry', params
  end

  #Get playlist information. 
  #To get songs as well, call getPlaylist.
  def get_playlist_info playlist_id
    params = { 'playlistID' => playlist_id }
    send_request 'getPlaylistInfo', params
  end

  #Get a subset of today's popular songs, from the Grooveshark popular billboard.
  def get_popular_songs_today limit = 10
    params = { 'limit' => limit }
    send_request 'getPopularSongsToday', params
  end

  #Get a subset of this month's popular songs, from the Grooveshark popular billboard.
  def get_popular_songs_month limit = 10
    params = { 'limit' => limit }
    send_request 'getPopularSongsMonth', params
  end

  #Useful for testing if the service is up. 
  #Returns "Hello, World" in various languages.
  def ping_service
    send_request 'pingService'
  end

  #Describe service methods
  def get_service_description
    send_request 'getServiceDescription'
  end

  #Undeletes a playlist.
  def undelete_playlist playlist_id
    params = { 'playlistID' => playlist_id }
    send_request 'undeletePlaylist', params
  end

  #Deletes a playlist.
  def delete_playlist playlist_id
    params = { 'playlistID' => playlist_id }
    send_request 'deletePlaylist', params
  end

  #Get songs on a playlist. Use getPlaylist instead.
  def get_playlist_songs playlist_id, limit = 10
    params = { 'playlistID' => playlist_id, 'limit' => limit }
    send_request 'getPlaylistSongs', params
  end

  #Get playlist info and songs.
  def get_playlist playlist_id, limit = 10
    params = { 'playlistID' => playlist_id, 'limit' => limit }
    send_request 'getPlaylist', params
  end

  #Set playlist songs, overwrites any already saved
  def set_playlist_songs playlist_id, song_id
    params = { 'playlistID' => playlist_id, 'songIDs' => song_id }
    send_request 'setPlaylistSongs', params
  end

  #Create a new playlist, optionally adding songs to it.
  def create_playlist name, song_id
    params = { 'name' => name, 'songIDs' => song_id }
    send_request 'createPlaylist', params
  end

  #Renames a playlist.
  def rename_playlist name, playlist_id
    params = { 'name' => name, 'playlistID' => playlist_id }
    send_request 'renamePlaylist', params
  end

  #Authenticate a user using an established session, 
  #a login and an md5 of their password.
  def authenticate login, password
    password = Digest::MD5.hexdigest password
    params = { 'login' => login, 'password' => password }
    send_request 'authenticate', params
  end

  #Get userID from username
  def get_userid_from_username username
    params = { 'username' => username }
    send_request 'getUserIDFromUsername', params
  end

  #Get meta-data information about one or more albums
  def get_albums_info album_id
    params = { 'albumIDs' => album_id }
    send_request 'getAlbumsInfo', params
  end

  #Get songs on an album. 
  #Returns all songs, verified and unverified
  def get_album_songs album_id, limit = 10
    params = { 'albumID' => album_id, 'limit' => limit }
    send_request 'getAlbumSongs', params
  end

  #Get meta-data information about one or more artists
  def get_artists_info artist_id
    params = { 'artistIDs' => artist_id }
    send_request 'getArtistsInfo', params
  end

  #Get information about a song or multiple songs.
  #The songID(s) should always be passed in as an array.
  def get_songs_info song_id
    params = { 'songIDs' => song_id }
    send_request 'getSongsInfo', params
  end

  #Check if an album exists
  def get_does_album_exists album_id
    params = { 'albumID' => album_id }
    send_request 'getDoesAlbumExists', params
  end

  #Check if a song exists
  def get_does_song_exists song_id
    params = { 'songID' => song_id }
    send_request 'getDoesSongExists', params
  end

  #Check if an artist exists
  def get_does_album_exists artist_id
    params = { 'artistID' => artist_id }
    send_request 'getDoesArtistExists', params
  end

  #Authenticate a user (login) using an established session. 
  #Please use the authenticate method instead.
  def authenticate_user username, token
    params = { 'username' => username, 'token' => token }
    send_request 'authenticateUser', params
  end

  #Get an artist's verified albums
  def get_artist_verified_albums artist_id
    params = { 'artistID' => artist_id }
    send_request 'getArtistVerifiedAlbums', params
  end

  #Get an artist's albums, verified and unverified
  def get_artist_albums artist_id
    params = { 'artistID' => artist_id }
    send_request 'getArtistAlbums', params
  end

  #Get 100 popular songs for an artist
  def get_artist_popular_songs artist_id
    params = { 'artistID' => artist_id }
    send_request 'getArtistPopularSongs', params
  end
end
