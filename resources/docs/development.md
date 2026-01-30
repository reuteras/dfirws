# Development

## Development Environment

TODO

## Tools to install when available

- [mvt](https://github.com/mvt-project/mvt) - currently says in the [documentation](https://docs.mvt.re/en/latest/install/) _MVT does not currently officially support running natively on Windows_. When installed add link to this [article](https://www.group-ib.com/blog/pegasus-spyware/).

## Tool registry helpers

When using a central `$TOOLS_REGISTRY`, you can list all tools that download from GitHub releases like this:

```powershell
$TOOLS_REGISTRY.Values | Where-Object {
    $_.Download -and $_.Download.Type -eq "github-release"
}
```

## Maybe later

- [qiling](https://github.com/qilingframework/qiling)
