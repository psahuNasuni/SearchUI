/**
 * @jest-environment jsdom
 */
 import {replaceAll,paginationTrigger,indexChange,appendData} from './search.js';


var charsTest = '[[This is "the" [test] TEXT]]'
var chars = ['[', ']', '\\', '"']
charsTest = charsTest.split(",")
var arr =['1','2','3']
var testDiv = document.createElement('div')

test('Remove the special characters', () => {
    expect(replaceAll(chars,charsTest)).toMatch('ThisisthetestTEXT');
  });

test('Return Div element for pagination', () => {
    expect(paginationTrigger("volume1")).toMatch("[object HTMLDivElement]");
  });

  test('Return Div element for number of results', () => {
    expect(indexChange()).toMatch("<p class=\"result-status\">Found 0 results.</p>");
  });

  test('Return Div element', () => {
    expect(appendData(testDiv,arr)).toMatch("<p class=\"result-status\">Found 0 results.</p>");
  });

  // indexChange