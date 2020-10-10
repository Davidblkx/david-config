/** Interface example for an app manifest */

interface AppManifest {
    /** name of app */
    name: string
    /** script path or package name */
    path?: string
    /** required apps to install before */
    deps?: string[]
    /** package manager to use */
    type?: 'package' | 'script'
    /** target os, defaults to '*' */
    target?: 'win' | 'linux' | '*'
}

type AppManifestList = string | AppManifest | AppManifest[]