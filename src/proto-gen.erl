-module(proto-gen).
-record(protoClass, {package, name, methods=[]}).
gen(FileName, PackageName) ->
  {ok, Device} = file:open(FileName, [read]),
  try read_file(Device, #protoClass{package=PackageName}, io:get_line(Device, ""), none) of
    unfinished_interface -> throw(unfinished_record);
    Class -> write_proto_file(Class)
  after file:close(Device)
  end.

read_file(Device, Class, eof, none) -> Class;
read_file(Device, Class, eof, _) -> unfinished_interface;

read_file(Device, Class, Line, none) ->
  case find_array(string:tokens(Line, " "), "interface", "{") of
    not_found -> read_file(Device, Class,io:get_line(Device, ""), none);
    InterfaceName -> read_file(Device, Class#protoClass{name=InterfaceName},io:get_line(Device, ""), interface)
  end;
read_file(Device, Class, Line, interface) -> Class; % todo: impl
read_file(Device, Class, Line, method_param) -> Class; % todo: impl
read_file(Device, Class, Line, method_return) -> Class; % todo: impl

%% find something inside, sandwiched by prefix & suffix
find_array([], _, _) -> not_found;
find_array([Prefix|[Found|_]], Prefix, "") -> Found;
find_array([Prefix|[Found|[Suffix|_]]], Prefix, Suffix) -> Found;
find_array([_|Tail], Prefix, Suffix) -> find_array(Tail, Prefix, Suffix).

write_proto_file(Class) when is_record(Class, protoClass) -> true; % todo: impl
write_proto_file(_) -> throw(invalid_record).