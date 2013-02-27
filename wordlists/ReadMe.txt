Selecting a word list format:

Word lists are provided in 4 formats:
1. Uncompressed word list
2. Uncompressed GSPL format
3. zLib compressed word list
4. zLib compressed GSPL format

Selecting a word list format generally involves balancing file size against parsing time. Because uncompressing the word lists does not have a major impact on parsing time, your choices will usually be between the two compressed formats. The first two uncompressed formats are provided mainly for reference.

The standard compressed word list is about 60% larger than the compressed GSPL format, but it will parse in about 100ms, versus 2-3 seconds. The longer parse time for GSPL is alleviated somewhat by the ability to do polite background parsing (to avoid application stalling or animation stuttering).

If you are targeting the desktop (with AIR for example), or high bandwidth online users, you may want to choose the compressed word list format. If you are targeting lower bandwidth users, or are seeking to reduce server load, you will likely want to use the compressed GSPL format.

Please read the SPL Specifications document in the docs folder for more information on word list formats.
