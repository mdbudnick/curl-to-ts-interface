# Curl Response Typescript Interface Generator

This Bash script retrieves a JSON response from a public endpoint using curl and generates TypeScript interfaces based on the response.

## Usage

```shell
./generate_interface.sh [-u <URL>] [-f <FILENAME>] [-i <INTERFACE_NAME>]
```

Optional arguments:
- `-f <FILENAME>`: Specify the output filename for the TypeScript interface. If not provided, the default filename will be `/tmp/response_<TIMESTAMP>.ts`.
- `-i <INTERFACE_NAME>`: Specify the name of the top-level TypeScript interface. If not provided, the default interface name will be `Response`.
- `-u <URL>`: Specify the public endpoint URL to retrieve the JSON response from. If not provided, the default URL can be set in `generate_interface.sh`

## Examples

1. Generate TypeScript interface using default values set in script:
```shell
./generate_interface.sh
```

2. This will retrieve the JSON response from the specified endpoint (`https://jsonplaceholder.typicode.com/posts/1/comments`), generate the TypeScript interface, and save it as `/tmp/response_example.ts` with the interface name set to `ResponseExample`:
```shell
./generate_interface.sh -f response_example -i ResponseExample -u https://jsonplaceholder.typicode.com/posts/1/comments

TypeScript interface generated: /tmp/response_example.ts
export type ResponseExampleItem1 = { postId: number, id: number, name: string, email: string, body: string }
export type ResponseExample = ResponseExampleItem1[]
```
---

Feel free to modify the script or use it as a starting point to suit your needs. Enjoy generating TypeScript interfaces for your API responses!