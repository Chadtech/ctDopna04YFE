{
  "targets": [
    {
      "target_name": "NtCpp",
      "sources": [ "src/Nt.cpp" ],
      "include_dirs": ["<!(node -e \"require('nan')\")" ]
    }
  ]
}