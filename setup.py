from setuptools import setup, find_packages

setup(
    name="hyccup",
    version="0.1.0",
    description="A port of Clojure Hiccup for Hy",
    author="Guillaume Fayard",
    auhtor_email="guillaume.fayard@pycolore.fr",
    license="MIT",
    keywords="template html hiccup hy",
    packages=find_packages(),
    package_data={"*": ['*.hy', '__pycache__/*']},
    # url="https://github.com/Arkelis/hyccup",
    install_requires=["hy>=1.0a1"],
    python_requires=">=3.9")
