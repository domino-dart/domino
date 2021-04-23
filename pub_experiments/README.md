# Experiments to demonstrate use cases for pub-dev.

## Notes

 * case 01: virtual dom with List-based composition model
   * predates `if` conditions and `for` loops inside list/map

 * case 02: incremental dom with template compiler
   * can work without the template compiler
   * found a bug in template compiler

 * case 03: dynamic dom - the element definition may contain functions that can be evaluated separately
   * designed for browser in mind (build on component tree, evaluate it on new data)
   * has similar template compiler as the incremental dom

 * case 04: virtual dom with Element-based composition model
   * using `domino` as backend, only to demonstrate how the API could look like

## Target template

```
<div>
{{#tags}}
  {{#has_href}}
    <a class="package-tag{{#status}} {{status}}{{/status}}" href="{{{href}}}"{{#title}} title="{{title}}"{{/title}}>{{text}}</a>
  {{/has_href}}
  {{^has_href}}
    <span class="package-tag{{#status}} {{status}}{{/status}}"{{#title}} title="{{title}}"{{/title}}>{{text}}</span>
  {{/has_href}}
{{/tags}}
</div>
```

https://github.com/dart-lang/pub-dev/blob/master/app/lib/frontend/templates/views/pkg/tags.mustache#L12-L19
