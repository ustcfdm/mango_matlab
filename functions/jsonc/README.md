# matlab_jsonc
MgRemoveJsoncComments: Remove comments in a json string for matlab to decode. \
MgReadJsoncFile: Read and decode jsonc file. \
MgSaveToJsonFile: Write structure to json file.

- This code uses c library [rapidjson](https://github.com/Tencent/rapidjson).
- C++ style comments are supported.
- Tail comma is supported.

Example
```matlab
% read json string with comments from a file
jsc = fileread("filename.jsonc");
% remove comments
js = MgRemoveJsoncComments(jsc);
% decode json string with internal function jsondecode
jo = jsondecode(js);

% directly read jsonc file
j = MgReadJsoncFile("filename.jsonc");

% write structure to json file
MgSaveToJsonFile(j, "filename2.jsonc");
```

