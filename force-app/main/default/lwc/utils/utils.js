export function parseExpression(expression, obj) {
  console.log("expression init", expression);
  var found = [];
  var rxp = /{([^}]+)}/g;
  var curMatch;

  while ((curMatch = rxp.exec(expression))) {
    found.push(curMatch[1]);
  }

  found.forEach((val) => {
    let objVal = obj[val];
    if (typeof objVal === "string") {
      objVal = `'${objVal}'`;
    }
    expression = expression.replace(`{${val}}`, objVal);
  });

  // console.log("expression transformed", expression);

  return eval(expression);
}