### [캡슐화]

* Private 배열을 외부에서 접근하여 배열 수정과 객체 속성 변경이 가능해지는 취약점
  따라서, public으로 선언된 메서드의 인자를 private 선언된 배열로 저장되지 않도록 한다.

##### [안전하지 않은 코드]

```java
public void setValueField(String[] valueField) {
    this.valueField = valueField;
}
```

##### [안전한 코드]

```java
this.valueField = new String[valueField.length];
for (int i=0; i<valueField.length; i++) {
    this.valueField[i] = valueField[i];
}
```

