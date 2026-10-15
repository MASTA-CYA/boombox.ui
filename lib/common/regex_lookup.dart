class RegexLookup {
  static final RegExp Url = RegExp(
      r"^((((H|h)(T|t)|(F|f))(T|t)(P|p)((S|s)?))\://)?(www.|[a-zA-Z0-9].)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,6}(\:[0-9]{1,5})*(/($|[a-zA-Z0-9\.\,\;\?\'\\\+&amp;%\$#\=~_\-@]+))*$");
  static final RegExp Website = RegExp(
    r'((https?:www\.)|(https?:\/\/)|(www\.))'
    '[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}'
    '(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?',
  );
}
