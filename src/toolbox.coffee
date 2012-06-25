wait = exports.wait = (t=0) -> (f) -> setTimeout f, t
async = exports.async = (f) -> setTimeout f, 0