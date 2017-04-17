# HTTP Live Streaming Parser

### Playlist Tags

- [x] EXTM3U
- [x] EXT-X-VERSION

### Master Playlist Tags

- [x] EXT-X-MEDIA
- [x] EXT-X-STREAM-INF
- [x] EXT-X-I-FRAME-STREAM-INF
- [x] EXT-X-SESSION-DATA
- [x] EXT-X-SESSION-KEY

### Media or Master Playlist Tags

- [x] EXT-X-INDEPENDENT-SEGMENTS
- [x] EXT-X-START

### Media Segment Tags

- [x] EXTINF
- [x] EXT-X-BYTERANGE
- [x] EXT-X-DISCONTINUITY
- [x] EXT-X-KEY
- [x] EXT-X-MAP
- [ ] EXT-X-PROGRAM-DATE-TIME
    - [x] Tag Definition
    - [ ] Date Parsing - It turns out [NSISO8601DateFormatter is dysfunctional](https://twitter.com/fcanas/status/853738641356705792)
- [ ] EXT-X-DATERANGE

### Media Playlist Tags

- [x] EXT-X-TARGETDURATION
- [x] EXT-X-MEDIA-SEQUENCE
- [x] EXT-X-DISCONTINUITY-SEQUENCE
- [x] EXT-X-ENDLIST
- [ ] EXT-X-PLAYLIST-TYPE
- [x] EXT-X-I-FRAMES-ONLY

### Other

- [ ] EXT-X-BITRATE - The undocumented `EXT-X-BITRATE` tag appears in Apple's
                      own example HLS streams as a media segment tag.
                      Technically, it would be a comment tag. Should it be
                      handled independently? Probably not.
